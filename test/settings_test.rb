require 'test_helper'

context 'The Settings class' do

  context 'reads settings' do
    asserts('returns a list of search terms') { Settings['sections'] }.any?
  end

  context 'writes settings' do
    setup { Settings['sections'] = %w(iphone windows7) }
    asserts('expected sections') { Settings['sections'] }.equals(%w(iphone windows7))
  end

end
