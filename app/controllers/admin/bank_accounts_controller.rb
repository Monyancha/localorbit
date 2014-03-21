class Admin::BankAccountsController < AdminController
  before_filter :find_entity

  def index
    @bank_accounts = @entity.bank_accounts
  end

  def new
    @bank_account = @entity.bank_accounts.build
  end

  def create
    results = AddBankAccountToEntity.perform(entity: @entity, bank_account_params: bank_account_params, representative_params: representative_params)

    if results.success?
      redirect_to [:admin, @entity, :bank_accounts]
    else
      @bank_account = results.bank_account
      render :new
    end
  end

  def verify
    @bank_account = @entity.bank_accounts.find(params[:bank_account_id])
  end

  def verification
    @bank_account = @entity.bank_accounts.find(params[:bank_account_id])

    results = VerifyBankAccount.perform(bank_account: @bank_account, verification_params: verification_params)

    if results.success?
      redirect_to [:admin, @entity, :bank_accounts]
    else
      flash.now[:alert] = "Could not verify bank account."
      render :verify
    end
  end

  private

  def find_entity
    entity_type = params[:market_id].present? ? :market : :organization
    @entity = send("find_#{entity_type}".to_sym)
  end

  def find_market
    current_user.managed_markets.find(params[:market_id])
  end

  def find_organization
    current_user.managed_organizations.find(params[:organization_id])
  end

  def bank_account_params
    params.require(:bank_account).permit(
      :bank_name,
      :last_four,
      :balanced_uri,
      :account_type
    )
  end

  def representative_params
    params.require(:representative).permit(
      :name,
      :ein,
      {dob: [:year, :month, :day]},
      :ssn_last4,
      {address: [:line1, :postal_code]}
    )
  end

  def verification_params
    params.require(:verification).permit(:amount_1, :amount_2)
  end
end

