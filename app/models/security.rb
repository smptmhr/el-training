class Security < ApplicationRecord
  # ランダムな22文字のトークンを返す
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # 渡された文字列のハッシュ値を返す
  def self.digest(string)
    # ハッシュ生成のコスト(＝安全性) テスト環境:低, 本番環境:高
    cost = if ActiveModel::SecurePassword.min_cost
              BCrypt::Engine::MIN_COST
            else
              BCrypt::Engine.cost
            end
    BCrypt::Password.create(string, cost:)
  end
end