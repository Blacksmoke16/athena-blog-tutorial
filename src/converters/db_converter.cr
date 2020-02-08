struct Blog::Converters::DB(T)
  include ART::ParamConverterInterface(T)

  # :inherit:
  def convert(request : HTTP::Request) : T
    # Be sure to handle any possible exceptions here to return more helpful errors to the client.
    model = T.find request.path_params["id"]
    raise ART::Exceptions::NotFound.new "An item with the provided ID could not be found" unless model
    model
  end
end
