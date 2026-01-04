module AccountScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :account
    default_scope { Current.account ? where(account_id: Current.account.id) : all }
    before_validation :assign_account
  end

  private

  def assign_account
    self.account ||= Current.account if Current.account
  end
end
