Rails.application.routes.default_url_options[:host] = 'Figaro.env.email_host'

Rails.application.routes.draw do
  mount Sidekiq::Web, at: '/sidekiq'

  namespace :api, defaults: { format: :json } do
    namespace :v1 do

      ###

      namespace :trees do
        resources :templates, only: %i[show create update destroy] do
          scope module: :templates do
            resources :nodes, only: %i[index]
          end
        end

        resources :instances, only: %i[show create destroy] do
          scope module: :instances do
            resources :nodes, only: %i[index]
          end
        end

        namespace :templates do
          resources :nodes, only: %i[create update destroy]
        end

        namespace :instances do
          resources :nodes, only: %i[] do
            scope module: :nodes do
              resource :completion, only: %i[create destroy]
            end
          end
        end
      end

      resources :organizations, only: %i[show create update destroy]

      ###

    end
  end
end
