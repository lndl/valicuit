require 'spec_helper'

RSpec.describe Valicuit::AfipService do
  describe '.cuit_exists?' do
    let(:afip_service) { Valicuit::AfipService.new }
    context 'when service is up' do
      context 'when cuit is found' do
        before do
          expect(afip_service).to \
            receive(:person_from).with('30615459190')
            .and_return({ 'success' => true, 'data' => { 'id' => 1 } })
        end
        it 'returns true' do
          expect(afip_service.cuit_exists?('30615459190'))
            .to be true
        end
      end
      context 'when cuit is not found' do
        before do
          expect(afip_service).to \
            receive(:person_from).with('20000000019')
            .and_return({ 'success' => false,
                          'error' => { 'mensaje' => 'no existe' } })
        end
        it 'returns false' do
          expect(afip_service.cuit_exists?('20000000019'))
            .to be false
        end
      end
    end
    context 'when service is down or is taking so long' do
      before do
        # Simulates connection problems
        expect(afip_service).to \
          receive(:do_http_get_to_afip)
          .and_raise Net::ReadTimeout
      end
      it 'raises a Valicuit::AfipServiceDownException' do
        expect do
          afip_service.cuit_exists?('30615459190')
        end.to raise_error(Valicuit::AfipServiceDownException)
      end
    end
  end
end
