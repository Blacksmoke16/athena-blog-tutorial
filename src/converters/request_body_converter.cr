struct Blog::Converters::RequestBody(T)
  include ART::ParamConverterInterface(T)

  # :inherit:
  def convert(request : HTTP::Request) : T
    # Be sure to handle any possible exceptions here to return more helpful errors to the client.
    raise ART::Exceptions::BadRequest.new "Request body is empty" unless body = request.body.try &.gets_to_end

    # Deserialize the object
    obj = T.from_json(body)

    if request.method == "PUT"
      # Deserialize the request body to get its ID to lookup the corresponding record to handle PUT (update) requests
      # TODO: Make this less hacky?  Probably build something into the serializer to allow customizing how the object gets instantiated for properties to be applied?
      data = JSON.parse body

      raise ART::Exceptions::NotFound.new "An Item with the provided ID could not be found" unless (id = data["id"]?) && (existing_record = T.find id)

      # Set the ID on the deserialized entity to the id of the existing record now that we know it exists
      obj.id = existing_record.id

      # Update new record to Granite knows it should be an UPDATE not an INSERT
      obj.new_record = false
    end

    # Run the validations
    obj.validate!

    # Return the object
    obj
  rescue ex : Assert::Exceptions::ValidationError
    raise ART::Exceptions::UnprocessableEntity.new ex.to_s
  end
end
