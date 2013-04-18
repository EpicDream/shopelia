require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  fixtures :users, :products, :merchants, :orders, :payment_cards, :order_items
  
  setup do
    @user = users(:elarch)
    @product = products(:usbkey)
    @merchant = merchants(:rueducommerce)
    @order = orders(:elarch_rueducommerce)
    @card = payment_cards(:elarch_hsbc)
    @content = { 
      "questions" => [
        { "id" => "3" }
      ],
      "products" => [
        { "url" => products(:usbkey).url,
          "delivery_text" => "Shipping", 
          "price_text" => "Price text", 
          "product_title" => "Usbkey", 
          "product_image_url" => "image.jpg", 
          "price_delivery" => 2, 
          "price_product" => 9 
        },
        { "url" => products(:headphones).url,
          "delivery_text" => "Shipping", 
          "price_text" => "Price text", 
          "product_title" => "Headphones", 
          "product_image_url" => "image.jpg", 
          "price_delivery" => 0, 
          "price_product" => 5 
        }
      ],
      "billing" => {
        "price" => 14,
        "shipping" => 2
      }
    }    
  end
  
  test "it should create order" do
    order = Order.new(
      :user_id => @user.id,
      :merchant_id => @merchant.id)
    assert order.save, order.errors.full_messages.join(",")
    assert_equal :pending, order.state
    assert order.uuid.present?
  end
  
  test "it should create order from urls" do
    order = Order.new(
      :user_id => @user.id,
      :urls => ["http://www.rueducommerce.fr/productA", "http://www.rueducommerce.fr/productB"])
    assert order.save, order.errors.full_messages.join(",")
    assert_equal 2, order.order_items.count
  end

  test "it shouldn't accept urls from different merchants" do
    order = Order.create(
      :user_id => @user.id,
      :urls => ["http://www.rueducommerce.fr/productA", "http://www.amazon.fr/productB"])
    assert_equal 1, order.order_items.count
  end
  
  test "it should start order" do
    @order.start
    assert_equal :ordering, @order.reload.state
  end
  
  test "it should fail order" do
    @order.process "failure", { "message" => "yop" }
    assert_equal :error, @order.reload.state
    assert_equal "yop", @order.message
  end
  
  test "it should set message" do
    @order.process "message", { "message" => "bla" }
    assert_equal "bla", @order.message    
  end

  test "it should process confirmation request" do
    @order.process "assess", @content
    assert_equal :pending_confirmation, @order.reload.state
    assert_equal 14, @order.price_total
    assert_equal 2, @order.price_delivery
    
    item = @order.order_items.where(:product_id => products(:usbkey).id).first
    assert_equal "Shipping", item.delivery_text
    assert_equal "Price text", item.price_text
    assert_equal "Usbkey", item.product_title
    assert_equal "image.jpg", item.product_image_url
    assert_equal 2, item.price_delivery
    assert_equal 9, item.price_product
  end

  test "it should process question and answers" do
    content = { 
      "questions" => [
        { "id" => "1",
          "text" => "Color?",
          "options" => [
            { "blue" => "Bleu" },
            { "red" => "Rouge" }
          ]
        }
      ]
    }
    @order.process "ask", content
    assert_equal :pending_answer, @order.reload.state
    
    questions = @order.questions
    assert questions.present?
    assert_equal 1, questions.size
    
    question = questions.first
    assert_equal "Color?", question["text"]
    assert_equal "1", question["id"]
    assert_equal 2, question["options"].size
    
    @order.process("answer", {"1" => "blue"})
    hash = @order.send(:prepare_answers_hash).first
    assert_equal "1", hash[:question_id]
    assert_equal "blue", hash[:answer]
  end
  
  test "it should confirm order" do
    @order.process "assess", @content
    assert_equal :pending_confirmation, @order.reload.state
    @order.process "confirm", { "payment_card_id" => @card.id }
    assert_equal :finalizing, @order.reload.state
  end

  test "it should cancel order" do
    @order.process "assess", @content
    assert_equal :pending_confirmation, @order.reload.state
    @order.process "cancel", {}
    assert_equal :canceled, @order.reload.state
  end

  test "it should fail order if no card present" do
    @order.process "assess", @content
    assert_equal :pending_confirmation, @order.reload.state
    @order.process "confirm", {}
    assert_equal :error, @order.reload.state
  end
  
end
