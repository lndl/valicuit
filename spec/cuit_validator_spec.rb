require 'spec_helper'

RSpec.describe ActiveModel::Validations::CuitValidator do
  before do
    TestModel.reset_callbacks(:validate)
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

      it 'gracefully handles nil input values' do
        validator.send(:separate_cuit_groups, nil).each do |group|
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
        expect(TestModel.new(cuit: '20000000019')).to be_valid
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
        it 'must return false for a nil value' do
          expect(TestModel.new(cuit: nil)).to be_invalid
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
        expect(TestModel.new(cuit: '20-00000001-9')).to be_valid
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
    context 'with dni compatible option' do
      before do
        TestModel.validates :cuit, cuit: { dni_compatible: :dni }
      end
      it 'must return true when CUIT/CUIL is valid and central part of CUIT is equal to DNI' do
        expect(TestModel.new(cuit: '30615459190', dni: '61545919')).to be_valid
        expect(TestModel.new(cuit: '20118748698', dni: '11874869')).to be_valid
        expect(TestModel.new(cuit: '20120112989', dni: '12011298')).to be_valid
        expect(TestModel.new(cuit: '27049852032', dni: '04985203')).to be_valid
        expect(TestModel.new(cuit: '23218381669', dni: '21838166')).to be_valid
        expect(TestModel.new(cuit: '30709316547', dni: '70931654')).to be_valid
        expect(TestModel.new(cuit: '20000000019', dni: '00000001')).to be_valid
      end
      it 'must return false when CUIT/CUIL is valid but central part of CUIT is not equal to DNI' do
        expect(TestModel.new(cuit: '30615459190', dni: '62545919')).to be_invalid
        expect(TestModel.new(cuit: '20118748698', dni: '11875869')).to be_invalid
        expect(TestModel.new(cuit: '20120112989', dni: '12011278')).to be_invalid
        expect(TestModel.new(cuit: '27049852032', dni: '04945203')).to be_invalid
        expect(TestModel.new(cuit: '23218381669', dni: '21838196')).to be_invalid
        expect(TestModel.new(cuit: '30709316547', dni: '70901654')).to be_invalid
        expect(TestModel.new(cuit: '20000000019', dni: '03000001')).to be_invalid
      end
      it 'must leave a specific message over :cuit in #errors array' do
        record = TestModel.new(cuit: '20120112989', dni: '12011278')
        record.valid?
        expect(record.errors[:cuit]).to match_array(['cuit_dni_incompatible'])
      end
    end
    context 'with gender compatible option' do
      before do
        TestModel.validates :cuit, cuit: { gender_compatible: { field: :gender, male: 'M', female: 'F', company: 'C' } }
      end
      it 'must return true when CUIT/CUIL is valid and gender part is compatible with gender model' do
        expect(TestModel.new(cuit: '20120112989', gender: 'M')).to be_valid
        expect(TestModel.new(cuit: '27049852032', gender: 'F')).to be_valid
        expect(TestModel.new(cuit: '30615459190', gender: 'C')).to be_valid
        expect(TestModel.new(cuit: '23218381669', gender: 'M')).to be_valid
        expect(TestModel.new(cuit: '23218381669', gender: 'F')).to be_valid
      end
      it 'must return false when CUIT/CUIL is valid but gender part is invalid' do
        expect(TestModel.new(cuit: '17049852032', gender: 'F')).to be_invalid
      end
      it 'must return false when CUIT/CUIL is valid but gender part is incompatible with gender model' do
        expect(TestModel.new(cuit: '20120112989', gender: 'F')).to be_invalid
        expect(TestModel.new(cuit: '27049852032', gender: 'M')).to be_invalid
        expect(TestModel.new(cuit: '27049852032', gender: 'C')).to be_invalid
      end
      it 'must leave a specific message over :cuit in #errors array' do
        record = TestModel.new(cuit: '20120112989', gender: 'F')
        record.valid?
        expect(record.errors[:cuit]).to match_array(['cuit_gender_incompatible'])
      end
    end
  end
end
