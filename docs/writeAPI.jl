function writeAPIcontents(name::String)
    return  """
# $(name)API

```@meta
CurrentModule = Ai4EComponentLib.$(name)
```

```@contents
Pages = ["$(name).md"]
```

## Index

```@index
Pages = ["$(name).md"]
```

## $(name) Components

```@autodocs
Modules = [$(name)]
```

"""
end