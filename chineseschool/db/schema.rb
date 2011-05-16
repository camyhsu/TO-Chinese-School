# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110515181027) do

  create_table "addresses", :force => true do |t|
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.string   "home_phone"
    t.string   "cell_phone"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "families", :force => true do |t|
    t.integer  "parent_one_id"
    t.integer  "parent_two_id"
    t.integer  "address_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "families_children", :id => false, :force => true do |t|
    t.integer  "family_id"
    t.integer  "child_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "grades", :force => true do |t|
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "short_name"
    t.integer  "next_grade"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instructor_assignments", :force => true do |t|
    t.integer  "school_year_id"
    t.integer  "school_class_id"
    t.integer  "instructor_id"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
  end

  create_table "people", :force => true do |t|
    t.string   "english_last_name"
    t.string   "english_first_name"
    t.string   "chinese_name"
    t.string   "gender"
    t.integer  "birth_year"
    t.integer  "birth_month"
    t.string   "native_language"
    t.integer  "address_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rights", :force => true do |t|
    t.string   "name"
    t.string   "controller"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rights_roles", :id => false, :force => true do |t|
    t.integer  "right_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer  "role_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "school_class_active_flags", :force => true do |t|
    t.integer  "school_class_id"
    t.integer  "school_year_id"
    t.boolean  "active",          :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "school_class_active_flags", ["school_class_id"], :name => "index_school_class_active_flags_on_school_class_id"
  add_index "school_class_active_flags", ["school_year_id"], :name => "index_school_class_active_flags_on_school_year_id"

  create_table "school_classes", :force => true do |t|
    t.string   "english_name"
    t.string   "chinese_name"
    t.string   "description"
    t.string   "location"
    t.integer  "max_size"
    t.integer  "min_age"
    t.integer  "max_age"
    t.integer  "grade_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "short_name"
  end

  create_table "school_years", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "registration_start_date"
    t.date     "registration_75_percent_date"
    t.date     "registration_50_percent_date"
    t.date     "registration_end_date"
    t.date     "refund_75_percent_date"
    t.date     "refund_50_percent_date"
    t.date     "refund_25_percent_date"
    t.date     "refund_end_date"
    t.integer  "age_cutoff_month"
    t.integer  "registration_fee_in_cents",    :default => 2000,  :null => false
    t.integer  "tuition_in_cents",             :default => 38000, :null => false
    t.integer  "book_charge_in_cents",         :default => 2000,  :null => false
    t.integer  "pva_membership_due_in_cents",  :default => 1500,  :null => false
    t.integer  "ccca_membership_due_in_cents", :default => 2000,  :null => false
  end

  create_table "student_class_assignments", :force => true do |t|
    t.integer  "student_id"
    t.integer  "grade_id"
    t.integer  "school_class_id"
    t.integer  "elective_class_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "school_year_id"
  end

  add_index "student_class_assignments", ["school_year_id"], :name => "index_student_class_assignments_on_school_year_id"

  create_table "timed_tokens", :force => true do |t|
    t.string   "token"
    t.integer  "person_id"
    t.datetime "expiration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "password_hash"
    t.string   "password_salt"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
