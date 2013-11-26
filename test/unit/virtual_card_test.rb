require 'test_helper'

class VirtualCardTest < ActiveSupport::TestCase

  test "it should create virtualis card" do
    card = VirtualCard.new(amount:100, provider:"virtualis")
    assert card.save, card.errors.full_messages.join(", ")

    assert_equal "virtualis", card.provider
    assert_equal 100, card.amount
    assert card.cvd_id.present?

    assert_equal 16, card.number.length
    assert_equal 2, card.exp_month.length
    assert_equal 4, card.exp_year.length
    assert_equal 3, card.cvv.length

    r = Virtualis::Card.detail({reference: card.cvd_id})
    assert_equal('ok', r['status'])
  end
end
