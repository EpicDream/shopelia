class Psp::LeetchiUser < Psp::LeetchiWrapper

  def create user
    remote_user = Leetchi::User.create({
        'Tag' => user.id.to_s,
        'Email' => user.email,
        'FirstName' => user.first_name,
        'LastName' => user.last_name,
        'Nationality' => user.nationality.iso,
        'Birthday' => user.birthdate.to_i,
        'PersonType' => 'NATURAL_PERSON',
        'CanRegisterMeanOfPayment' => true,
        'IP' => user.ip_address
    })
    if remote_user["ID"].present?
      psp_user = PspUser.new(
        :psp_id => @psp.id, 
        :user_id => user.id, 
        :remote_user_id => remote_user["ID"].to_i)
      if psp_user.save
        return true
      else
        local_error psp_user
      end
    else
      remote_error remote_user
    end
    false
  end

  def update user
    remote_user = Leetchi::User.update(user.leetchi.remote_user_id, {
        'Email' => user.email,
        'FirstName' => user.first_name,
        'LastName' => user.last_name,
        'Nationality' => user.nationality.iso,
        'Birthday' => user.birthdate.to_i,
    })
    if remote_user["ID"].nil?
      remote_error remote_user
      false
    else
      true
    end
  end

end

