module Integrity
  class MangoPay

    def self.verify_report report=""
      log = []
      contribution_ids_A = []
      report.split(/\n/).each do |line|
        next if line == "" || line == "textbox1" || line == "Report shopelia" || line == "TypeTransaction,ID,CreationDate,UserId,Lastname,Firstname,Amount,Fees,DebitedUserId,DebitedWalletId,CreditedUserId1,CreditedWalletId"
        data = line.split(/,/)
        if data.count != 12
          log << "Invalid line format -- #{line}"
          next
        end
        case data[0]
        when "contribution"
          mp_contribution_id = data[1].to_i
          mp_user_id = data[3].to_i
          mp_amount = data[6].to_i
          mp_wallet_id = data[11].to_i
          t = BillingTransaction.where(mangopay_contribution_id:mp_contribution_id).first
          if t.nil?
            log << "Impossible to find order with transaction_id #{mp_contribution_id} -- #{line}"
          elsif t.user.mangopay_id != mp_user_id
            log << "User ID doesn't match -- #{line}"
          elsif t.mangopay_destination_wallet_id != mp_wallet_id
            log << "Wallet ID doesn't match -- #{line}"
          elsif t.amount != mp_amount
            log << "Amounts not consistent -- #{line}"
          end
          contribution_ids_A << mp_contribution_id
        else
          log << "Unexpected TypeTransaction -- #{line}"
        end
      end
      contribution_ids_B = BillingTransaction.successfull.where("created_at >= ? and created_at < ?", 31.days.ago.to_date.to_s, Time.now.to_date.to_s).where(processor:'mangopay').map(&:mangopay_contribution_id)
      if contribution_ids_A.to_set != contribution_ids_B.to_set
        log << "Inconsistent contribution_ids ! REPORT:#{contribution_ids_A} vs DB:#{contribution_ids_B}"
      end
      log
    end

  end
end


