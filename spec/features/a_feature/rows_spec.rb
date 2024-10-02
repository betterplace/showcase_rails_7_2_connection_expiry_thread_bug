require_relative '../../spec_helper.rb'
require_relative '../../rails_helper.rb'

describe 'Row' do
  context 'with a row' do
    let!(:row) { Row.create! }

    it 'fights over threads and transactions 1' do
      Row.new

      visit '/rows'

      expect(page).not_to have_content('Failure')
    end

    it 'fights over threads and transactions', js: true do
      Row.new

      visit '/rowsi'

      expect(page).not_to have_content('Failure')
    end
  end
end
