#RubyNos

A gem to provide microservices autodiscovery to Ruby microservices. This gem allows a microservice to publish its
existence on a cloud, store other microservices information and public its API.

#Configuration

You can configure the following characteristics of the gem:

###Agent characteristics

Every microservice will have an Agent object that will be the responsible of sending the messages to the cloud. You can
configure these characteristics:

 * **Cloud_uuid:** The identifier of the cloud where all the microservices will be exchanging messages.
 * **Port:** UDP port where the Agent will be listening to other microservices messages.
 * **Group_address:** The IP group where all the microservices will be listening to the messages.
 * **Time_between_messages:** Allows to specify how much time will pass between the keep alive messages.
 * **Hops:** Number of hops for the messages.

An example of configuration would be:

  ```ruby
    config = load_file('ruby_nos')
    RubyNos.configure do |c|
      c.cloud_uuid = config['cloud']
      c.port = config['port']
      c.group_address = config['group_address']
      c.time_between_messages = config['time_between_messages']
    end
  ```

To make the agent start sending and listening to messages you will have to add the following line to your code:

  ```ruby
      RubyNos::Agent.new.configure
  ```

###Publish API

To publish the API of a microservice you will have to create a RestAPI agent and associate it to the Agent.

  ```ruby
      ruby_nos_api = RubyNos::RestApi.new
      ruby_nos_agent.rest_api = ruby_nos_api
   ```

To publish an endpoint you have to add to the rest_api object.


  ```ruby
      ruby_nos_api.add_endpoint(path: <endpoint path> , type: <"PUB", "HCK", "INT">, port: <application port>)
  ```

You will have to specify the type of the endpoint, there are three types supported right now:

 * **PUBLIC(PUB):** If the endpoint belongs to a public API.
 * **INTERNAL(INT):** If the endpoint belongs to an internal API.
 * **HEALTHCHECK(HCK):** For a healthcheck endpoint.



