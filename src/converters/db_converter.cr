@[ADI::Register]
struct Blog::Converters::DB < ART::ParamConverterInterface
  configuration model : Granite::Base.class

  # :inherit:
  #
  # Be sure to handle any possible exceptions here to return more helpful errors to the client.
  def apply(request : HTTP::Request, configuration : Configuration) : Nil
    return unless primary_key = request.attributes.get "id", Int32
    raise ART::Exceptions::NotFound.new "An item with the provided ID could not be found" unless model = configuration.model.find primary_key
    request.attributes.set configuration.name, model, configuration.model
  end
end
