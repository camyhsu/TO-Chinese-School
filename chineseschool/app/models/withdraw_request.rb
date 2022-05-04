class WithdrawRequest < ActiveRecord::Base

  STATUS_APPROVED = 'A'
  STATUS_DECLINED = 'D'
  STATUS_CANCELLED = 'C'
  STATUS_PENDING_FOR_APPROVAL = 'P'

  attr_accessible :refund_ccca_due_in_cents, :refund_grand_total_in_cents, :refund_pva_due_in_cents, :request_by_address, :request_by_id, :request_by_name, :school_year_id, :status_by_id, :status_code

  has_many :withdraw_request_details, dependent: :destroy

  belongs_to :request_by, class_name: 'Person', foreign_key: 'request_by_id'
  belongs_to :status_by, class_name: 'Person', foreign_key: 'status_by_id'
  belongs_to :school_year, class_name: 'SchoolYear', foreign_key: 'school_year_id'

  validates :request_by_address, :request_by_name, presence: true

  def caculate_refund_grand_total_in_cents
    self.refund_grand_total_in_cents = self.refund_pva_due_in_cents + self.refund_ccca_due_in_cents
    self.withdraw_request_details.each do |withdraw_request_detail|
      self.refund_grand_total_in_cents = self.refund_grand_total_in_cents + withdraw_request_detail.refund_total_in_cents
    end
  end

  def refund_grand_total
    self.refund_grand_total_in_cents / 100.0
  end

  def refund_ccca_due
    self.refund_ccca_due_in_cents / 100.0
  end

  def refund_pva_due
    self.refund_pva_due_in_cents / 100.0
  end

  def self.find_withdraw_request_as_parent_in(school_year, person_id)
    WithdrawRequest.all :conditions => ["school_year_id = ? and request_by_id = ? ", school_year.id, person_id], :order => 'updated_at DESC'
  end

  def self.has_withdraw_request_as_parent_in?(school_year, person_id)
    WithdrawRequest.count(
        :conditions => ["school_year_id = ? and request_by_id = ? ", school_year.id, person_id]) > 0
  end

  def status
    return 'CANCELLED' if self.status_code == STATUS_CANCELLED
    return 'APPROVED' if self.status_code == STATUS_APPROVED
    return 'DECLINED' if self.status_code == STATUS_DECLINED
    return 'PENDING FOR APPROVAL'
  end

  def cancelled?
    self.status_code == STATUS_CANCELLED
  end

  def approved?
    self.status_code == STATUS_APPROVED
  end

  def declined?
    self.status_code == STATUS_DECLINED
  end

  def save_with_side_effects?
    begin
      WithdrawRequest.transaction do
        save!
        move_student_class_assignment_to_withdrawal_record
      end
      true
    rescue => e
      puts "Approve withdraw request failed - Exception => #{e.inspect}"
      (errors[:base] << 'System Transaction Failed') if errors.empty?
      false
    end
  end

  def move_student_class_assignment_to_withdrawal_record
    current_school_year = SchoolYear.current_school_year
    self.withdraw_request_details.each do |withdraw_request_detail|
      withdrawal_record = WithdrawalRecord.new
      withdrawal_record.school_year = current_school_year
      withdrawal_record.student = withdraw_request_detail.student
      withdrawal_record.withdrawal_date = self.updated_at

      # Grab the registration time and set the student status to NOT registered
      student_status_flag = withdraw_request_detail.student.student_status_flag_for current_school_year
      unless student_status_flag.nil?
        withdrawal_record.registration_date = student_status_flag.last_status_change_date
        # If only withdraw elective class, then not update registered = false
        unless withdraw_request_detail.elective_class_only == 'Y'
          student_status_flag.registered = false
        end
        student_status_flag.last_status_change_date = self.updated_at
        student_status_flag.save!
      end

      # Move class assignment data to withdrawal record and destroy the class assignment
      student_class_assignment = withdraw_request_detail.student.student_class_assignment_for current_school_year
      # If only withdraw elective class, then not destroy student_class_assignment, just update student_class_assignment.elective_class_id = 0
      if withdraw_request_detail.elective_class_only == 'Y'
        withdrawal_record.grade_id = 0
        withdrawal_record.school_class_id = 0
        withdrawal_record.elective_class_id = student_class_assignment.elective_class_id
        student_class_assignment.elective_class_id = 0
        student_class_assignment.save!

        # Set elective_class_id = 0 for registration_preference
        registration_preference = withdraw_request_detail.student.registration_preference_for(current_school_year)
        unless registration_preference.nil?
          registration_preference.elective_class_id = 0
          registration_preference.save!
        end
      else
        unless student_class_assignment.nil?
          withdrawal_record.grade_id = student_class_assignment.grade_id
          withdrawal_record.school_class_id = student_class_assignment.school_class_id
          withdrawal_record.elective_class_id = student_class_assignment.elective_class_id
          student_class_assignment.destroy
        end
      end
      withdrawal_record.save!

      # Notify instructors about the withdrawal
      if PacificDate.tomorrow >= current_school_year.start_date
        #WithdrawalMailer.instructor_notification(self.student, withdrawal_record.school_class).deliver unless withdrawal_record.school_class.nil?
        WithdrawalMailer.instructor_notification(withdraw_request_detail.student, withdrawal_record.elective_class).deliver unless withdrawal_record.elective_class.nil?
      end
    end
  end

end
