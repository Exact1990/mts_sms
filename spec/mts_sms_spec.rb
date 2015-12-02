require 'spec_helper'

describe 'Mts SMS' do
  before do
    WebMock.stub_request(:get, "http://www.mcommunicator.ru/m2m/m2m_api.asmx?WSDL").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => File.new(File.dirname(__FILE__)+'/fixtures/soap/m2m_api.asmx.xml'), :headers => {})

    # Correct send message request
    WebMock.stub_request(:post, "http://www.mcommunicator.ru/m2m/m2m_api.asmx").
        with(:body => File.open(File.dirname(__FILE__)+'/fixtures/soap/send_message/success/request.xml').read.to_s,
             :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                          'Content-Length'=>'611', 'Content-Type'=>'text/xml;charset=UTF-8',
                          'Soapaction'=>'"http://mcommunicator.ru/M2M/SendMessage"', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => File.new(File.dirname(__FILE__)+'/fixtures/soap/send_message/success/response.xml'),
                  :headers => {})

    # Incorrect msid request
    WebMock.stub_request(:post, "http://www.mcommunicator.ru/m2m/m2m_api.asmx").
        with(body: File.open(File.dirname(__FILE__)+'/fixtures/soap/send_message/incorrect_msid/request.xml').read.to_s,
             headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                       'Content-Length'=>'601', 'Content-Type'=>'text/xml;charset=UTF-8',
                       'Soapaction'=>'"http://mcommunicator.ru/M2M/SendMessage"', 'User-Agent'=>'Ruby'}).
        to_return(:status => 500, :body => File.new(File.dirname(__FILE__)+'/fixtures/soap/send_message/incorrect_msid/response.xml'),
                  :headers => {})
  end

  context 'correct auth data' do
    before do
      MtsSms.config(login: 'test', password: 'test', naming: '79857707575')
    end

    it 'should status success after sending sms' do
      response = MtsSms::Message.new('test').send_sms('79222222222')
      expect(response[:success]).to eq(true)
      expect(response[:info][:send_message_response][:send_message_result]).to eq("2648")
    end

    it 'should status error after sending sms with incorrect msid' do
      response = MtsSms::Message.new('test').send_sms('7')
      expect(response[:success]).to eq(false)
      expect(response[:info][:detail][:code]).to eq('506')
    end
  end

  context 'incorrect auth data' do
    before do
      WebMock.stub_request(:post, "http://www.mcommunicator.ru/m2m/m2m_api.asmx")
          .with(:body => File.open(File.dirname(__FILE__)+'/fixtures/soap/send_message/incorrect_auth_data/request.xml').read.to_s,
           :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                        'Content-Length'=>'578', 'Content-Type'=>'text/xml;charset=UTF-8',
                        'Soapaction'=>'"http://mcommunicator.ru/M2M/SendMessage"', 'User-Agent'=>'Ruby'}).
          to_return(:status => 500, :body => File.new(File.dirname(__FILE__)+'/fixtures/soap/send_message/incorrect_auth_data/response.xml'),
                    :headers => {})
    end

    it 'should status error after sending sms without auth data' do
      MtsSms.config(login: nil, naming: nil)
      MtsSms.md5_password = nil
      response = MtsSms::Message.new('test').send_sms('79222222222')
      expect(response[:success]).to eq(false)
      expect(response[:info][:detail][:code]).to eq('103')
    end
  end
end
