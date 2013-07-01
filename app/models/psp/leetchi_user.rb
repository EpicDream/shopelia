class Psp::LeetchiUser < Psp::LeetchiWrapper

  def create user
    remote_user = Leetchi::User.create({
        'Tag' => user.id.to_s,
        'Email' => user.email,
        'FirstName' => user.first_name,
        'LastName' => user.last_name,
        'Nationality' => user.nationality.nil? ? "fr" : user.nationality.iso,
        'Birthday' => user.birthdate.nil? ? 30.years.ago.to_i : user.birthdate.to_i,
        'PersonType' => 'NATURAL_PERSON',
        'CanRegisterMeanOfPayment' => true,
        'IP' => user.ip_address
    })
    user.update_column :leetchi_created_at, Time.now
    if remote_user["ID"].present?
      user.update_column :leetchi_id, remote_user["ID"].to_i
      return true
    else
      remote_error remote_user
    end
    false
  end

  def update user
    remote_user = Leetchi::User.update(user.leetchi_id, {
        'Email' => user.email,
        'FirstName' => user.first_name,
        'LastName' => user.last_name,
        'Nationality' => user.nationality.nil? ? "fr" : user.nationality.iso,
        'Birthday' => user.birthdate.nil? ? 30.years.ago.to_i : user.birthdate.to_i
    })
    if remote_user["ID"].nil?
      remote_error remote_user
      false
    else
      true
    end
  end

end

