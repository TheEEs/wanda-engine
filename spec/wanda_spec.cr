require "./spec_helper"
require "http/client"

describe Wanda do
  context "send requests to server" do
    it "should return status code of 200" do
      response = HTTP::Client.get("http://localhost:3000/user")
      response.status_code.should eq 200
    end

    it "should create new user and return status code of 200" do
      response = HTTP::Client.post("http://localhost:3000/user", form: {
        "name"   => "Tran Ba Dat",
        "gender" => "male",
      })
      response.status_code.should eq 200
    end

    it "should update the last user then return status code of 200" do
      response = HTTP::Client.put("http://localhost:3000/user/1", form: {
        "name"   => "Dat Dep Try Than Thanh",
        "gender" => "male",
      })
      response.status_code.should eq 200
    end

    it "should delete the last user then return status code of 302" do
      response = HTTP::Client.delete("http://localhost:3000/user/2")
      response.status_code.should eq 302
    end

    it "enable csrf protection and expect request to return Forbbiden code (403)" do
      response = HTTP::Client.options("http://localhost:3000/raise_csrf")
      response.status_code.should eq 403
    end

    it "simulate put request via method overrider , expected status code of 200 and response body : put method" do
      response = HTTP::Client.post("http://localhost:3000/simulate_put",
        form: {
          "_method" => "put",
        })
      response.status_code.should eq 200
      response.body.should eq "put method"
    end
  end

  context "enable a websocket connection to testing server" do
    it "shoud establish an WebSocket Connection" do
      message = "Hello"
      ws = HTTP::WebSocket.new("localhost", "/chat", 3000)
      ws.on_message do |msg|
        CHANNEL.send(msg)
      end
      spawn do
        ws.run
      end
      ws.send(message)
      received_message = CHANNEL.receive
      received_message.should eq "send back:#{message}"
      ws.close
      sleep 1.second
    end
  end

end
