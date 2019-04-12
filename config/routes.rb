Rails.application.routes.draw do

     namespace :v1 do
        resources :users ,except: [:show, :edit] do
          collection do
            post   'confirm',           to: 'users#confirm',                      as: :confirm
            post   'login',             to: 'users#login',                        as: :login
          end
        end
    end
end
