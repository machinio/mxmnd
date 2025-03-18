require 'spec_helper'

def stub_mxmnd_request(ip, headers: {})
  response_path = './spec/features/mxmnd_res.txt'
  request_headers = {
    'Accept' => '*/*',
    'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'User-Agent' => 'mxmnd'
  }.merge(headers)
  stub_request(:get, "https://geoip.maxmind.com/geoip/v2.1/city/#{ip}").
    with(headers: request_headers).
    to_return(File.new(response_path))
end

describe Mxmnd do
  it 'raises BadRequest on missing IP address' do
    expect { Mxmnd.city(nil) }.to raise_error Mxmnd::BadRequest
  end

  describe 'accepts connection block' do
    before do
      stub_mxmnd_request('45.17.22.11', headers: { 'User-Agent' => 'Ruby MXMND' })
    end

    it 'works' do
      response = Mxmnd.city('45.17.22.11') do |conn|
        conn.headers['User-Agent'] = 'Ruby MXMND'
      end
      expect(response).to be_a(Hash)
    end
  end
end

describe 'Mxmnd.city response' do
  before do
    stub_mxmnd_request('45.17.22.11')
  end

  let(:response) { Mxmnd.city('45.17.22.11') }

  it 'should be a hash' do
    expect(response).to be_a(Hash)
  end

  it 'should have distinct keys' do
    key_array = [
      'city',
      'continent',
      'country',
      'location',
      'maxmind',
      'postal',
      'registered_country',
      'subdivisions',
      'traits'
    ]
    expect(presence_of_keys?(response, key_array)).to be(true)
  end

  context 'hash' do
    it 'key city should be a hash including 8 locales' do
      expect(response['city']['names'].length).to be 8
    end
    it 'key continent should be a hash including 8 locales' do
      expect(response['continent']['names'].length).to be 8
    end
    it 'key country should be a hash including 8 locales' do
      expect(response['country']['names'].length).to be 8
    end
    it 'key registered_country should be a hash including 8 locales' do
      expect(response['registered_country']['names'].length).to be 8
    end
    it 'key subdivisions should be an array' do
      expect(response['subdivisions']).to be_a(Array)
    end
  end
end
