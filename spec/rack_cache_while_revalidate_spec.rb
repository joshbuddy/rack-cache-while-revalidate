require 'spec_helper'


def build_builder(app)
  Rack::Builder.new {

    use Rack::Capabilities
    use Rack::CacheWhileRevalidate
    use Rack::Cache,
      :verbose     => true,
      :metastore   => 'heap:/',
      :entitystore => 'heap:/'

    run app
  }
end


describe "Rack Cache While Revalidate" do
  
  it "should pass uncached requests through normally" do
    app = mock('app')
    app.should_receive(:call).and_return [200, {}, ['oh yeah']]
    
    builder = build_builder(app)
    builder.call(Rack::MockRequest.env_for("http://127.0.0.1/testing")).last.should == ['oh yeah']
  end
  
  it "should serve stale requests while continuing on with the original request" do
    app = mock('app')
    app.should_receive(:call).and_return { sleep(2); [200, {'Cache-Control' => 'max-age=1'}, ['oh yeah']]}
    builder = build_builder(app)
    builder.call(Rack::MockRequest.env_for("http://127.0.0.1/testing")).last.should == ['oh yeah']
    start_time = Time.new.to_f
    builder.call(Rack::MockRequest.env_for("http://127.0.0.1/testing")).last.should == ['oh yeah']
    (Time.new.to_f - start_time).should < 1
  end
  
end