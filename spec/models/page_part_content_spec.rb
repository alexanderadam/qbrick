require 'spec_helper'

describe 'PagePart' do
  describe 'Content' do
    before do
      @content = Kuhsaft::PagePart::Content.new
    end
    
    it 'should belong to a LocalizedPage' do
      @content.should respond_to(:localized_page)
    end
    
    it 'should have a content to store serialized data' do
      @content.should respond_to(:content)
    end
    
    context 'class' do
      it 'should keep a list of the serializeable attributes' do
        Kuhsaft::PagePart::Content.serializeable_attributes.should be_a(Array)
      end
      
      it 'should keep a list of searchable attributes' do
        Kuhsaft::PagePart::Content.searchable_attributes.should be_a(Array)
      end
      
      it 'should have a list of page_part_types' do
        Kuhsaft::PagePart::Content.page_part_types.should be_all { |p| p.superclass.should eq Kuhsaft::PagePart::Content }
      end
      
      it 'should have the Markdown PagePart by default' do
        Kuhsaft::PagePart::Content.descendants.should include(Kuhsaft::PagePart::Markdown)
      end
      
      it 'should convert to_name' do
        Kuhsaft::PagePart::Markdown.to_name.should eq('Markdown')
      end
    end
  end
  
  describe 'Markdown' do
    before do
      @m = Kuhsaft::PagePart::Markdown.new
    end
    
    it 'should have text' do
      @m.should respond_to(:text)
    end
    
    it 'should have searchable text' do
      Kuhsaft::PagePart::Markdown.searchable_attributes.should include(:text)
    end
    
    it 'should store text' do
      @m.text = 'hi'
      @m.text.should eq('hi')
    end
    
    it 'should restore the serialized attributes when loaded' do
      m = Kuhsaft::PagePart::Markdown.create(:text => 'hi')
      m2 = Kuhsaft::PagePart::Markdown.find(m.id)
      m2.text.should eq('hi')
    end
  end
end