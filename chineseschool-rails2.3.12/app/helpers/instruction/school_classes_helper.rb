module Instruction::SchoolClassesHelper

  def format_family_fields(student)
    families_as_child = student.find_families_as_child
    return format_family_fields_without_parent(student) if families_as_child.empty?
    
    output = ''
    output << format_parent_fields(families_as_child)
    append_email_phone_fields output, families_as_child[0]
    output
  end


  private

  def format_family_fields_without_parent(student)
    # this could happen if the student is a parent - we still want to show email
    # and home phone even though parents are empty fields
    output = '<td></td><td></td>'
    families_as_parent = student.find_families_as_parent
    if families_as_parent.empty?
      # no address information at all
      output << '<td></td><td></td>'
    else
      append_email_phone_fields output, families_as_parent[0]
    end
    output
  end

  def append_email_phone_fields(output, family)
    output << "<td>#{h(family.address.email)}</td>"
    output << "<td>#{h(family.address.home_phone)}</td>"
  end

  def format_parent_fields(families)
    father_field = '<td>'
    mother_field = '<td>'
    families.each do |family|
      add_parent(family.parent_one, father_field, mother_field)
      add_parent(family.parent_two, father_field, mother_field)
    end
    father_field << '</td>'
    mother_field << '</td>'
    "#{father_field}\n#{mother_field}"
  end

  def add_parent(parent, father_field, mother_field)
    return if parent.nil?
    if parent.gender == Person::GENDER_MALE
      father_field << "#{h(parent.name)}&nbsp;"
    else
      mother_field << "#{h(parent.name)}&nbsp;"
    end
  end
end
