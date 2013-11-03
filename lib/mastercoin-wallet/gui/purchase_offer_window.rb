module MastercoinWallet 
  class PurchaseOfferWindow < Qt::Dialog
    include Bitcoin::Builder
    include MastercoinWallet::Builder

    slots 'send_transaction()'

    def initialize(parent=nil)
      super(parent)

      @ui = Ui_PurchaseOffer.new
      @ui.setupUi(self)

      @amount_input = findChild(Qt::LineEdit, "amount_input")
      @password_input = findChild(Qt::LineEdit, "password_input")
      @address_input = findChild(Qt::LineEdit, "address_input")
      @fee_input = findChild(Qt::LineEdit, "fee_input")

      @submit = findChild(Qt::PushButton, "submit_button")

      @amount_input.validator = Qt::DoubleValidator.new(0.00000001, 10000,8, @amount_input)
      @fee_input.validator = Qt::DoubleValidator.new(0.00000001, 10000,8, @fee_input)

      @currency_select = findChild(Qt::ComboBox, "currency_box")
      # Dont allow real coins for now
      #      @currency_select.addItem(tr("Mastercoin"))
      @currency_select.addItem(tr("Test Mastercoin"))

      @submit.enabled = true

      connect(@submit, SIGNAL('clicked()'), self, SLOT('send_transaction()'))
    end

    def send_transaction
      @amount = @amount_input.text()
      @receiving_address = @address_input.text()
      @password = @password_input.text()
      @fee = @fee_input.text()

      unless Bitcoin::valid_address?(@receiving_address)
        Qt::MessageBox.critical(self, tr("Invalid address"),
                                tr("Please fill in a valid Bitcoin/Mastercoin address"))
      end

      unless @receiving_address.empty? || @amount.empty? || @password.empty? || @fee.empty?
        data_keys = Mastercoin::PurchaseOffer.new(currency_id: 2, amount: (@amount.to_f * 1e8).to_i).encode_to_compressed_public_key(MastercoinWallet.config.address)
        create_transaction_with_keys(data_keys, force_fee: @fee)
        close()
      else
        Qt::MessageBox.critical(self, tr("Invalid form"),
                                tr("Please fill in all required inputs"))
      end

    end
  end
end