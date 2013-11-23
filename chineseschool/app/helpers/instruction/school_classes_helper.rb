module Instruction::SchoolClassesHelper

  def format_family_fields(student)
    families_as_child = student.find_families_as_child
    return format_family_fields_without_parent(student) if families_as_child.empty?

    family_fields = {}
    extract_parent family_fields, families_as_child
    extract_email_phone family_fields, families_as_child[0]
    family_fields
  end


  private

  def format_family_fields_without_parent(student)
    # this could happen if the student is a parent - we still want to show email
    # and home phone even though parents are empty fields
    family_fields = {}
    families_as_parent = student.find_families_as_parent
    unless families_as_parent.empty?
      extract_email_phone family_fields, families_as_parent[0]
    end
    family_fields
  end

  def extract_email_phone(family_fields, family)
    family_fields[:email_field] = family.address.email
    family_fields[:phone_field] = family.address.home_phone
  end

  def extract_parent(family_fields, families)
    father_names = []
    mother_names = []
    families.each do |family|
      add_parent(family.parent_one, father_names, mother_names)
      add_parent(family.parent_two, father_names, mother_names)
    end
    family_fields[:father_field] = father_names.join(', ') unless father_names.empty?
    family_fields[:mother_field] = mother_names.join(', ') unless mother_names.empty?
  end

  def add_parent(parent, father_names, mother_names)
    return if parent.nil?
    if parent.gender == Person::GENDER_MALE
      father_names << parent.name
    else
      mother_names << parent.name
    end
  end
end
