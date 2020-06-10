@[ADI::Register]
# This is required in order to use `CrSerializer` with Athena.
#
# NOTE: This will not be required when `Athena::Serializer` is released and integrated into `Athena`, probably in version `0.10.0`.
struct Blog::Listeners::View
  include AED::EventListenerInterface

  def self.subscribed_events : AED::SubscribedEvents
    AED::SubscribedEvents{
      ART::Events::View => 50,
    }
  end

  def call(event : ART::Events::View, dispatcher : AED::EventDispatcherInterface) : Nil
    event.response = if event.request.route.return_type == Nil?
                       ART::Response.new status: :no_content, headers: get_headers
                     else
                       ART::Response.new(headers: get_headers) { |io| io.print event.view.data.to_json }
                     end
  end

  private def get_headers : HTTP::Headers
    HTTP::Headers{"content-type" => "application/json"}
  end
end
