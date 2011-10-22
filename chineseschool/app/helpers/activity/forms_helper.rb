module Activity::FormsHelper
  
  def append_family_fields(row, student)
    families_as_child = student.find_families_as_child
    return append_family_fields_without_parent(row, student) if families_as_child.empty?
    
    append_parent_fields row, families_as_child[0]
    append_email_phone_fields_to_array row, families_as_child[0]
  end


  private

  def append_family_fields_without_parent(row, student)
    # this could happen if the student is a parent - we still want to show email
    # and home phone even though parents are empty fields
    row << ''
    row << ''
    families_as_parent = student.find_families_as_parent
    if families_as_parent.empty?
      # no address information at all
      row << ''
      row << ''
    else
      append_email_phone_fields_to_array row, families_as_parent[0]
    end
  end

  def append_email_phone_fields_to_array(row, family)
    append_field row, family.address.email
    append_field row, family.address.home_phone
  end

  def append_parent_fields(row, family)
    append_field row, family.parent_one.try(:name)
    append_field row, family.parent_two.try(:name)
  end
  
  def append_field(row, field)
    if field.nil?
      row << ''
    else
      row << field
    end
  end
end
