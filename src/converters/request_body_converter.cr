# The converter can be a struct/class, I'm going to use a struct for this example.
@[ADI::Register]
struct Blog::Converters::RequestBody < ART::ParamConverterInterface
  configuration model : Granite::Base.class

  # :inherit:
  def apply(request : HTTP::Request, configuration : Configuration) : Nil
    # Be sure to handle any possible exceptions here to return more helpful errors to the client.
    raise ART::Exceptions::BadRequest.new "Request body is empty" unless body = request.body.try &.gets_to_end

    # Deserialize the object
    obj = configuration.model.from_json body

    if request.method == "PUT"
      # Deserialize the request body to get its ID to lookup the corresponding record to handle PUT (update) requests
      # TODO: Make this less hacky?  Probably build something into the serializer to allow customizing how the object gets instantiated for properties to be applied?
      data = JSON.parse body

      # Return a 404 if the data does not have an `id` or the record doesn't exist
      raise ART::Exceptions::NotFound.new "An Item with the provided ID could not be found" unless (id = data["id"]?) && (existing_record = configuration.model.find id)

      # Set the ID on the deserialized entity to the id of the existing record now that we know it exists
      obj.id = existing_record.id

      # Update new record to Granite knows it should be an UPDATE not an INSERT
      obj.new_record = false
    end

    # Run the validations
    obj.validate!

    # Add the resolved object to the request's attributes
    request.attributes.set configuration.name, obj, configuration.model
  rescue ex : Assert::Exceptions::ValidationError
    # Raise a 422 error if the object failed its validations
    raise ART::Exceptions::UnprocessableEntity.new ex.to_s
  end
end
