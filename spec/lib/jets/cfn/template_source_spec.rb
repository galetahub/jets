# frozen_string_literal: true

describe Jets::Cfn::TemplateSource do
  let(:path) { '/tmp/test.txt' }
  let(:template) do
    described_class.new(path, s3_bucket: s3_backet)
  end

  context 'without s3_backet' do
    let(:s3_backet) { nil }
    let(:body) { 'long file body' }

    it 'must read file from disk' do
      expect(template).to receive(:body).and_return(body)

      expect(template.to_h[:template_body]).to eq body
    end
  end

  context 'with s3_backet' do
    let(:s3_backet) { 'test' }
    let(:url) { "https://s3.amazonaws.com/#{s3_backet}/test" }

    it 'must upload file to s3' do
      expect(template).to receive(:upload_file_to_s3).and_return(url)

      expect(template.to_h[:template_url]).to eq url
    end
  end
end
