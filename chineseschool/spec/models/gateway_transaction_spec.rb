require 'spec_helper'

describe GatewayTransaction, 'setting approval status based on Authorize.Net response' do

  before(:each) do
    @gateway_transaction = GatewayTransaction.new
  end

  it 'should set approval status to APPROVAL_STATUS_APPROVED if Authorized.Net return response code 1' do
    @gateway_transaction.set_approval_status_based_on_authorize_net_response(1)
    expect(@gateway_transaction.approval_status).to eq(GatewayTransaction::APPROVAL_STATUS_APPROVED)
  end

  it 'should set approval status to APPROVAL_STATUS_DECLINED if Authorized.Net return response code 2' do
    @gateway_transaction.set_approval_status_based_on_authorize_net_response(2)
    expect(@gateway_transaction.approval_status).to eq(GatewayTransaction::APPROVAL_STATUS_DECLINED)
  end

  it 'should set approval status to APPROVAL_STATUS_ERROR if Authorized.Net return response code 3' do
    @gateway_transaction.set_approval_status_based_on_authorize_net_response(3)
    expect(@gateway_transaction.approval_status).to eq(GatewayTransaction::APPROVAL_STATUS_ERROR)
  end

  it 'should set approval status to APPROVAL_STATUS_ERROR if Authorized.Net return response code 4' do
    @gateway_transaction.set_approval_status_based_on_authorize_net_response(4)
    expect(@gateway_transaction.approval_status).to eq(GatewayTransaction::APPROVAL_STATUS_ERROR)
  end

  it 'should set approval status to APPROVAL_STATUS_ERROR if Authorized.Net return response code that is not defined' do
    @gateway_transaction.set_approval_status_based_on_authorize_net_response(5)
    expect(@gateway_transaction.approval_status).to eq(GatewayTransaction::APPROVAL_STATUS_ERROR)
  end
end