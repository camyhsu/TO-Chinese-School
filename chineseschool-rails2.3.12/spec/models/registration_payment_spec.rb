require 'spec_helper'

describe RegistrationPayment, 'filling in due' do
  before(:each) do
    fake_school_year = SchoolYear.new
    @pva_due_in_cents = rand 10000
    fake_school_year.pva_membership_due_in_cents = @pva_due_in_cents
    @ccca_due_in_cents = rand 10000
    fake_school_year.ccca_membership_due_in_cents = @ccca_due_in_cents

    @registration_payment = RegistrationPayment.new
    @registration_payment.school_year = fake_school_year
    @registration_payment.paid_by = Person.new
    @registration_payment.student_fee_payments << StudentFeePayment.new
  end

  it 'should fill in zero for pva due if there are already two completed registration in the family' do
    @registration_payment.stubs(:calculate_ccca_due)
    @registration_payment.fill_in_due 2
    @registration_payment.pva_due_in_cents.should == 0
    @registration_payment.fill_in_due 3
    @registration_payment.pva_due_in_cents.should == 0
  end

  it 'should fill in single pva due if there is one completed registration in the family and one student registering' do
    @registration_payment.stubs(:calculate_ccca_due)
    @registration_payment.fill_in_due 1
    @registration_payment.pva_due_in_cents.should == @pva_due_in_cents
  end

  it 'should fill in single pva due if there is one student registering' do
    @registration_payment.stubs(:calculate_ccca_due)
    @registration_payment.fill_in_due 0
    @registration_payment.pva_due_in_cents.should == @pva_due_in_cents
  end

  it 'should fill in double pva due if there is two student registering' do
    @registration_payment.student_fee_payments << StudentFeePayment.new
    @registration_payment.stubs(:calculate_ccca_due)
    @registration_payment.fill_in_due 0
    @registration_payment.pva_due_in_cents.should == (@pva_due_in_cents * 2)
  end

  it 'should fill in double pva due if there is three or more student registering' do
    @registration_payment.student_fee_payments << StudentFeePayment.new
    @registration_payment.student_fee_payments << StudentFeePayment.new
    @registration_payment.stubs(:calculate_ccca_due)
    @registration_payment.fill_in_due 0
    @registration_payment.pva_due_in_cents.should == (@pva_due_in_cents * 2)
  end

  it 'should fill in 0 for ccca due if there is already one or more completed registration in the family' do
    setup_fake_family
    @fake_family.ccca_lifetime_member = false
    @registration_payment.fill_in_due 1
    @registration_payment.ccca_due_in_cents.should == 0
    @registration_payment.fill_in_due 2
    @registration_payment.ccca_due_in_cents.should == 0
  end

  it 'should fill in 0 for ccca due if the family is a ccca lifetime member' do
    setup_fake_family
    @fake_family.ccca_lifetime_member = true
    @registration_payment.fill_in_due 0
    @registration_payment.ccca_due_in_cents.should == 0
  end

  it 'should fill in ccca due if the family is not a ccca lifetime member and no completed registration in the family' do
    setup_fake_family
    @fake_family.ccca_lifetime_member = false
    @registration_payment.fill_in_due 0
    @registration_payment.ccca_due_in_cents.should == @ccca_due_in_cents
  end

  def setup_fake_family
    @fake_family = Family.new
    @registration_payment.paid_by.stubs(:families).returns([@fake_family])
  end
end

describe RegistrationPayment, 'calculating grand total' do
  before(:each) do
    @registration_payment = RegistrationPayment.new
    @pva_due_in_cents = rand 100000
    @registration_payment.pva_due_in_cents = @pva_due_in_cents
    @ccca_due_in_cents = rand 100000
    @registration_payment.ccca_due_in_cents = @ccca_due_in_cents

    @registration_fee_in_cents = rand 100000
    @book_charge_in_cents = rand 100000

    @first_student_fee_payment = StudentFeePayment.new
    @first_student_fee_payment.registration_fee_in_cents = @registration_fee_in_cents
    @first_student_fee_payment.book_charge_in_cents = @book_charge_in_cents
    @first_tuition_in_cents = rand 100000
    @first_student_fee_payment.tuition_in_cents = @first_tuition_in_cents
    @registration_payment.student_fee_payments << @first_student_fee_payment

    @second_student_fee_payment = StudentFeePayment.new
    @second_student_fee_payment.registration_fee_in_cents = @registration_fee_in_cents
    @second_student_fee_payment.book_charge_in_cents = @book_charge_in_cents
    @second_tuition_in_cents = rand 100000
    @second_student_fee_payment.tuition_in_cents = @second_tuition_in_cents
    @registration_payment.student_fee_payments << @second_student_fee_payment
  end

  it 'should add up all total tuition, fee, and due' do
    @registration_payment.grand_total_in_cents.should be_nil
    @registration_payment.calculate_grand_total
    @registration_payment.grand_total_in_cents.should == (@pva_due_in_cents + @ccca_due_in_cents +
        (@registration_fee_in_cents + @book_charge_in_cents) * 2 +
        @first_tuition_in_cents + @second_tuition_in_cents)
  end
end
