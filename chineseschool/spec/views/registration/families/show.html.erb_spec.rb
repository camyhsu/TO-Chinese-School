require 'spec_helper'

describe "/registration/families/show" do
  fixtures :families, :people, :families_children, :addresses
  
  before(:each) do
    @page_title = 'Family'
    assigns[:family] = families(:family_three)
    render 'registration/families/show'
  end

  it_should_behave_like 'titled page'
  
  it 'should have column headers in html table' do
    headers = []
    headers << 'Parent One'
    headers << 'Parent Two'
    headers << 'Children'
    headers << 'Address'
    show_that_table_headers_exist_with headers
  end

  it 'should show one family information in a html table' do
    response.should have_tag('tbody') do
      with_tag('tr', 1)
      with_tag('tr') do
        with_tag('td') do |td_elements|
          with_tag(td_elements[0], 'td', families(:family_three).parent_one.name)
          with_tag(td_elements[1], 'td', families(:family_three).parent_two.name)
          with_tag(td_elements[2], 'td', '')
          with_tag(td_elements[3], 'td', families(:family_three).address.street_address)
        end
      end
    end
  end
  
end


describe "/registration/families/show", 'displaying family missing one parent' do
  fixtures :families, :people, :families_children
  
  it 'should safely show family information if missing parent_one' do
    assigns[:family] = families(:family_two)
    render 'registration/families/show'
    response.should have_tag('tbody') do
      with_tag('tr', 1)
      with_tag('tr') do
        with_tag('td') do |td_elements|
          with_tag(td_elements[0], 'td', '')
          with_tag(td_elements[1], 'td', families(:family_two).parent_two.name)
        end
      end
    end
  end

  it 'should safely show family information if missing parent_two' do
    assigns[:family] = families(:family_one)
    render 'registration/families/show'
    response.should have_tag('tbody') do
      with_tag('tr', 1)
      with_tag('tr') do
        with_tag('td') do |td_elements|
          with_tag(td_elements[0], 'td', families(:family_one).parent_one.name)
          with_tag(td_elements[1], 'td', '')
        end
      end
    end
  end

end
