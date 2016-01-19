require 'spec_helper'

RSpec.describe ActiveModel::Validations::CuitValidator do
  before do
    TestModel.reset_callbacks(:validate)
  end

  context '#check_validity!' do
    context 'when pass cuil option as validator' do
      it 'returns the validation options passed (therefore, all is well defined)' do
        expect(TestModel.validates :cuit, cuil: true).to eq(cuil: true)
      end
    end
    context 'when invalid options are passed' do
      it 'throws an ArgumentError' do
        expect do
          TestModel.validates :cuit, cuit: { separator: '/', wrong_param: true }
        end.to raise_error(ArgumentError)
      end
    end
    context 'when valid options are passed' do
      it 'returns the validation options passed (therefore, all is well defined)' do
        expect(TestModel.validates :cuit, cuit: { separator: '/' }).to eq(cuit: { separator: '/' })
      end
    end
    context 'when no options are passed (only true)' do
      it 'returns the validation options passed (therefore, all is well defined)' do
        expect(TestModel.validates :cuit, cuit: true).to eq(cuit: true)
      end
    end
  end

  context '#separate_cuit_groups' do
    context 'without provide separator' do
      let(:validator) { ActiveModel::Validations::CuitValidator.new attributes: { _: :_ } }
      it 'must return an 3-elements Array (Happy)' do
        expect(validator.send(:separate_cuit_groups, '30615459190')).to be_an_instance_of(Array)
        expect(validator.send(:separate_cuit_groups, '30615459190').size).to eq(3)
      end

      it 'must return an 3-elements Array (Sad)' do
        expect(validator.send(:separate_cuit_groups, '306')).to be_an_instance_of(Array)
        expect(validator.send(:separate_cuit_groups, '306').size).to eq(3)
      end

      it 'each element must be an instance of String (Happy)' do
        validator.send(:separate_cuit_groups, '30615459190').each do |group|
          expect(group).to be_an_instance_of String
        end
      end

      it 'each element must be an instance of String (Sad)' do
        validator.send(:separate_cuit_groups, '306').each do |group|
          expect(group).to be_an_instance_of String
        end
      end
    end
    context 'providing separator' do
      let(:validator) do
        ActiveModel::Validations::CuitValidator.new attributes: { _: :_ },
          separator: '-'
      end
      it 'must return an 3-elements Array (Happy)' do
        expect(validator.send(:separate_cuit_groups, '30-61545919-0')).to be_an_instance_of(Array)
        expect(validator.send(:separate_cuit_groups, '30-61545919-0').size).to eq(3)
      end

      it 'must return an 3-elements Array (Sad)' do
        expect(validator.send(:separate_cuit_groups, '30- - - --')).to be_an_instance_of(Array)
        expect(validator.send(:separate_cuit_groups, '30- - - --').size).to eq(3)
      end

      it 'each element must be an instance of String (Happy)' do
        validator.send(:separate_cuit_groups, '30-61545919-0').each do |group|
          expect(group).to be_an_instance_of String
        end
      end

      it 'each element must be an instance of String (Sad)' do
        validator.send(:separate_cuit_groups, '306---').each do |group|
          expect(group).to be_an_instance_of String
        end
      end
    end
  end

  context '#valid' do
    context 'with standard options' do
      before do
        TestModel.validates :cuit, cuit: true
      end
      it 'must return true when CUIT/CUIL is valid' do
        expect(TestModel.new(cuit: '30615459190')).to be_valid
        expect(TestModel.new(cuit: '20118748698')).to be_valid
        expect(TestModel.new(cuit: '20120112989')).to be_valid
        expect(TestModel.new(cuit: '27049852032')).to be_valid
        expect(TestModel.new(cuit: '23218381669')).to be_valid
        expect(TestModel.new(cuit: '30709316547')).to be_valid
      end
      context 'when CUIT/CUIL has strange characters' do
        it 'must return false' do
          expect(TestModel.new(cuit: '2061s459190')).to be_invalid
        end
        it 'must leave a specific message over :cuit in #errors array' do
          record = TestModel.new(cuit: '2061s459190')
          record.valid?
          expect(record.errors[:cuit]).to match_array(['invalid_format'])
        end
      end
      context 'when CUIT/CUIL has not the correct length' do
        it 'must return false' do
          expect(TestModel.new(cuit: '301110')).to be_invalid
        end
        it 'must leave a specific message over :cuit in #errors array' do
          record = TestModel.new(cuit: '301110')
          record.valid?
          expect(record.errors[:cuit]).to match_array(['invalid_format'])
        end
      end
      context 'when CUIT/CUIL is logically invalid, because verification digit is incorrect' do
        it 'must return false' do
          expect(TestModel.new(cuit: '20111111110')).to be_invalid
        end
        it 'must leave a specific message over :cuit in #errors array' do
          record = TestModel.new(cuit: '20111111110')
          record.valid?
          expect(record.errors[:cuit]).to match_array(['invalid_v_digit'])
        end
      end
    end
    context 'with separator option' do
      before do
        TestModel.validates :cuit, cuit: { separator: '-' }
      end
      it 'must return true when CUIT/CUIL is valid' do
        expect(TestModel.new(cuit: '30-61545919-0')).to be_valid
        expect(TestModel.new(cuit: '20-11874869-8')).to be_valid
        expect(TestModel.new(cuit: '20-12011298-9')).to be_valid
        expect(TestModel.new(cuit: '27-04985203-2')).to be_valid
        expect(TestModel.new(cuit: '23-21838166-9')).to be_valid
        expect(TestModel.new(cuit: '30-70931654-7')).to be_valid
      end
      context 'when CUIT/CUIL has not the correct length' do
        it 'must return false' do
          expect(TestModel.new(cuit: '30-1110222222222-4')).to be_invalid
        end
        it 'must leave a specific message over :cuit in #errors array' do
          record = TestModel.new(cuit: '30-1110222222222-4')
          record.valid?
          expect(record.errors[:cuit]).to match_array(['invalid_format'])
        end
      end
      context 'when CUIT/CUIL has misplaced the separator' do
        it 'must return false' do
          expect(TestModel.new(cuit: '30-123-11114')).to be_invalid
        end
        it 'must leave a specific message over :cuit in #errors array' do
          record = TestModel.new(cuit: '30-123-11114')
          record.valid?
          expect(record.errors[:cuit]).to match_array(['invalid_format'])
        end
      end
    end
  end
end
