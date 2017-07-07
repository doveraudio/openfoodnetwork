module Spree
  class Gateway
    class StripeConnect < Gateway
      preference :enterprise_id, :integer

      attr_accessible :preferred_enterprise_id

      CARD_TYPE_MAPPING = {
        'American Express' => 'american_express',
        'Diners Club' => 'diners_club',
        'Visa' => 'visa'
      }.freeze

      def method_type
        'stripe'
      end

      def provider_class
        ActiveMerchant::Billing::StripeGateway
      end

      def payment_profiles_supported?
        true
      end

      def stripe_account_id
        StripeAccount.find_by_enterprise_id(preferred_enterprise_id).andand.stripe_user_id
      end

      def purchase(money, creditcard, gateway_options)
        provider.purchase(*options_for_purchase_or_auth(money, creditcard, gateway_options))
      end

      # def authorize(money, creditcard, gateway_options)
      #   provider.authorize(*options_for_purchase_or_auth(money, creditcard, gateway_options))
      # end

      # def capture(money, response_code, gateway_options)
      #   provider.capture(money, response_code, gateway_options)
      # end

      # def credit(money, creditcard, response_code, gateway_options)
      #   provider.refund(money, response_code, {})
      # end

      # def void(response_code, creditcard, gateway_options)
      #   provider.void(response_code, {})
      # end

      # def cancel(response_code)
      #   provider.void(response_code, {})
      # end

      def create_profile(payment)
        return unless payment.source.gateway_customer_profile_id.nil?
        options = {
          email: payment.order.email,
          login: Stripe.api_key,
        }.merge! address_for(payment)

        creditcard = card_to_store(payment.source)

        response = provider.store(creditcard, options)
        if response.success?
          payment.source.update_attributes!( cc_type: payment.source.cc_type, # side-effect of update_source!
                                             gateway_customer_profile_id: response.params['id'],
                                             gateway_payment_profile_id: response.params['default_source'] || response.params['default_card'])
        else
          payment.send(:gateway_error, response.message)
        end
      end

      private

      # In this gateway, what we call 'secret_key' is the 'login'
      def options
        options = super
        options.merge(:login => Stripe.api_key)
      end

      def options_for_purchase_or_auth(money, creditcard, gateway_options)
        options = {}
        options[:description] = "Spree Order ID: #{gateway_options[:order_id]}"
        options[:currency] = gateway_options[:currency]
        options[:stripe_account] = stripe_account_id

        creditcard = token_from_card_profile_ids(creditcard)

        [money, creditcard, options]
      end

      def address_for(payment)
        {}.tap do |options|
          if address = payment.order.bill_address
            options[:address] = {
              address1: address.address1,
              address2: address.address2,
              city: address.city,
              zip: address.zipcode
            }

            if country = address.country
              options[:address][:country] = country.name
            end

            if state = address.state
              options[:address].merge!(state: state.name)
            end
          end
        end
      end

      def update_source!(source)
        source.cc_type = CARD_TYPE_MAPPING[source.cc_type] if CARD_TYPE_MAPPING.include?(source.cc_type)
        source
      end

      def creditcard_to_store(source)
        source = update_source!(source)
        if source.number.blank? && source.gateway_payment_profile_id.present?
          # StripeJS Token
          source.gateway_payment_profile_id
        else
          # Spree::CreditCard object
          source
        end
      end

      def token_from_card_profile_ids(creditcard)
        token_or_card_id = creditcard.gateway_payment_profile_id
        customer = creditcard.gateway_customer_profile_id

        return nil if token_or_card_id.blank?

        # Assume the gateway_payment_profile_id is a token generated by StripeJS
        return token_or_card_id if customer.blank?

        # Assume the gateway_payment_profile_id is a Stripe card_id
        # So generate a new token, using the customer_id and card_id
        tokenize_instance_customer_card(customer, token_or_card_id)
      end

      def tokenize_instance_customer_card(customer, card)
        token = Stripe::Token.create({card: card, customer: customer}, stripe_account: stripe_account_id)
        token.id
      rescue Stripe::StripeError => e
        Rails.logger.error("Stripe Error: #{e}")
        nil
      end
    end
  end
end
