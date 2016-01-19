# Valicuit
Un validador de CUIT/CUIL para ActiveModel &amp; Rails.

## Instalación

Lo de siempre... agregar esta línea en el Gemfile del proyecto:

```
gem 'valicuit', github: 'lndl/valicuit'
```

Y, finalmente, ejecutar **bundle install**

## Uso

Es un validador más. Dentro de cualquier modelo se especifica que un atributo X se valide con cuit (o cuil, es indistinto), de esta forma:

```ruby
class Persona < ActiveRecord::Base
  validates :cuit, cuit: true  # Notar que también podría usarse cuil: true
end
```

Con esto, se dispone de validación por formato (por defecto 11 dígitos, sin separador) y por dígito verificador (con el algoritomo módulo 11)

## Opciones adicionales

Se puede agregar la opción de incluir y validar un separador para los grupos que componen el CUIT/CUIL, de esta forma:

```ruby
class Persona < ActiveRecord::Base
  validates :cuit, cuit: { separator: '-' }
end
```

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
