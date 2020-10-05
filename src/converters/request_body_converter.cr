# Define a custom `ASR::ObjectConstructorInterface` to allow sourcing the model from the database
# as part of `PUT` requests, and if the type is a `Granite::Base`.
#
# Alias our service to `ASR::ObjectConstructorInterface` so ours gets injected instead.
@[ADI::Register(alias: ASR::ObjectConstructorInterface)]
class DBObjectConstructor
  include Athena::Serializer::ObjectConstructorInterface

  # Inject `ART::RequestStore` in order to have access to the current request.
  # Also inject `ASR::InstantiateObjectConstructor` to act as our fallback constructor.
  def initialize(
    @request_store : ART::RequestStore,
    @fallback_constructor : ASR::InstantiateObjectConstructor
  ); end

  # :inherit:
  def construct(navigator : ASR::Navigators::DeserializationNavigatorInterface, properties : Array(ASR::PropertyMetadataBase), data : ASR::Any, type)
    # Fallback on the default object constructor if the type is not a `Granite` model.
    unless type <= Granite::Base
      return @fallback_constructor.construct navigator, properties, data, type
    end

    # Fallback on the default object constructor if the current request is not a `PUT`.
    unless @request_store.request.method == "PUT"
      return @fallback_constructor.construct navigator, properties, data, type
    end

    # Lookup the object from the database; assume the object has an `id` property.
    object = type.find data["id"].as_i

    # Return a `404` error if no record exists with the given ID.
    raise ART::Exceptions::NotFound.new "An item with the provided ID could not be found." unless object

    # Apply the updated properties to the retrieved record
    object.apply navigator, properties, data

    # Return the object
    object
  end
end

# Make the compiler happy when we want to allow any Granite model to be deserializable.
class Granite::Base
  include ASR::Model
end

# Define our converter, register it as a service, inheriting from the base interface struct.
@[ADI::Register]
struct Blog::Converters::RequestBody < ART::ParamConverterInterface
  # Define a custom configuration for this converter.
  # This allows us to provide a `model` field within the annotation
  # in order to define _what_ model should be used on deserialization.
  configuration model : Granite::Base.class

  # Inject the Serializer instance into our converter.
  def initialize(
    @serializer : ASR::SerializerInterface,
    @validator : AVD::Validator::ValidatorInterface
  ); end

  # :inherit:
  def apply(request : HTTP::Request, configuration : Configuration) : Nil
    # Be sure to handle any possible exceptions here to return more helpful errors to the client.
    raise ART::Exceptions::BadRequest.new "Request body is empty." unless body = request.body.try &.gets_to_end

    # Deserialize the object, based on the type provided in the annotation.
    object = @serializer.deserialize configuration.model, body, :json

    # Run the validations.
    violations = @validator.validate object

    # If there are any violations,
    unless violations.empty?
      # raise a validation failed exception.
      raise AVD::Exceptions::ValidationFailedError.new violations
    end

    # Add the resolved object to the request's attributes.
    request.attributes.set configuration.name, object, configuration.model
  end
end
