require 'spec_helper'

describe 'Mts SMS' do
  before do
    MtsSms.config(login: 'test', password: 'test', naming: '79857707575')

    WebMock.stub_request(:get, "http://www.mcommunicator.ru/m2m/m2m_api.asmx?WSDL").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => File.new(File.dirname(__FILE__)+'/fixtures/m2m_api.asmx.xml'), :headers => {})

    WebMock.stub_request(:post, "http://www.mcommunicator.ru/m2m/m2m_api.asmx").
        with(:body => File.open(File.dirname(__FILE__)+'/fixtures/soap_send_message_request.xml').read.to_s,
             :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                          'Content-Length'=>'611', 'Content-Type'=>'text/xml;charset=UTF-8',
                          'Soapaction'=>'"http://mcommunicator.ru/M2M/SendMessage"', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => File.new(File.dirname(__FILE__)+'/fixtures/soap_send_message_response.xml'), :headers => {})
  end

  it 'should status success after sending sms' do
    response = MtsSms::Message.new('test').send_sms('79222222222')
    expect(response[:success]).to eq(true)
    expect(response[:info][:send_message_response][:send_message_result]).to eq("2648")
  end
end
