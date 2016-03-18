pkgname=nzbwatch
_gitname=nzbwatch
pkgver=1
pkgrel=1
pkgdesc="Watch a folder for new NZB files and automatically upload to SABnzbd"
arch=('any')
url="https://github.com/tescorg/nzbwatch"
license=()
depends=('ruby')
makedepends=('git')
optdepends=('sabnzbd')
install=
source=("git+https://github.com/tescorg/nzbwatch")
md5sums=('SKIP') #generate with 'makepkg -g'

package() {
  install -Dm640 "${srcdir}/${_gitname}/${pkgname}-sample.yml"    "${pkgdir}/etc/${pkgname}-sample.yml"
  install -Dm755 "${srcdir}/${_gitname}/${pkgname}.rb"            "${pkgdir}/usr/bin/${pkgname}.rb"
  install -Dm777 "${srcdir}/${_gitname}/${pkgname}.service"       "${pkgdir}/usr/lib/systemd/user/${pkgname}.service"
}
