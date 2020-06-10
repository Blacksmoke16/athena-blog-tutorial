@[ADI::Register]
struct Blog::Converters::DB < ART::ParamConverterInterface
  # Define a customer configuration for this converter.
  # This allows us to provide a `model` field within the annotation
  # in order to define _what_ model should be queried for.
  configuration model : Granite::Base.class

  # :inherit:
  #
  # Be sure to handle any possible exceptions here to return more helpful errors to the client.
  def apply(request : HTTP::Request, configuration : Configuration) : Nil
    # Grab the `id` path parameter from the request's attributes
    primary_key = request.attributes.get "id", Int32

    # Raise a 404 if a record with the provided ID does not exist
    raise ART::Exceptions::NotFound.new "An item with the provided ID could not be found" unless model = configuration.model.find primary_key

    # Set the resolved model within the request's attributes
    # with a key matching the name of the argument within the converter annotation
    request.attributes.set configuration.name, model, configuration.model
  end
end
