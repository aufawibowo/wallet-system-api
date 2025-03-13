# app/controllers/wallets_controller.rb
class WalletsController < ApplicationController
  def balance
    wallet = Wallet.find(params[:id])
    # Optional check: ensure @current_user has permission to see this wallet
    # if wallet.owner != @current_user && !some_admin_check?
    #   return render json: { error: "Forbidden" }, status: :forbidden
    # end

    render json: { wallet_id: wallet.id, balance: wallet.balance.to_s }, status: :ok
  end
end
