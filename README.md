# Valicuit
Un validador de CUIT/CUIL para ActiveModel &amp; Rails.

## Instalación

Lo de siempre... agregar esta línea en el Gemfile del proyecto:

```
gem 'valicuit'
```

Y, finalmente, ejecutar **bundle install**

## Uso

Es un validador más. Dentro de cualquier modelo se especifica que un atributo X se valide con cuit, de esta forma:

```ruby
class Persona < ActiveRecord::Base
  validates :cuit, cuit: true
end
```

Con esto, se dispone de validación por longitud (por ahora 11 dígitos, sin separador (próximamente se mejorará)) y por dígito verificador (con el algoritomo módulo 11)

## Tests

Se corren con RSpec.

## Agradecimientos

- https://github.com/maxigarciaf/cuit_validator
- https://github.com/codegram/date_validator

## Contribuciones

1. Clonar el proyecto.
2. Crear un *feature branch* (`git checkout -b mi-nuevo-feature`).
3. *Commitear* los cambios realizados (`git commit -am 'Agrego algo nuevo o mejoro algo'`).
4. *Pushear* el *feature* (`git push origin mi-nuevo-feature`).
5. Crear un *Pull Request*.
