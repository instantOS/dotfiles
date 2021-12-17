# dotfiles

instantOS default dotfiles

## installation

Manually installing these dotfiles requires [imosid](https://github.com/instantos/imosid) to be installed. 

```sh
git clone --depth=1 https://github.com/instantos/dotfiles instantdotfiles
cd instantdotfiles/dotfiles
imosid apply .
```

imosid ensures that no existing dotfiles get overwritten and if there are
updates for dotfiles that originated from the instantos dotfiles they are only
applied to sections of the file that have not been customized by the user. 
