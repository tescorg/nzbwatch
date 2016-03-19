pkgname=nzbwatch-git
_gitname=nzbwatch
pkgver=r20.8a79065
pkgrel=1
pkgdesc="Watch a folder for new NZB files and automatically upload to SABnzbd"
arch=('any')
url="https://github.com/tescorg/nzbwatch"
license=()
conflicts=('nzbwatch')
provides=('nzbwatch')
depends=('ruby' 'ruby-rb-inotify')
makedepends=('git')
optdepends=('sabnzbd')
install=
source=("git+https://github.com/tescorg/nzbwatch")
md5sums=('SKIP')

package() {
  install -Dm644 "${srcdir}/${_gitname}/nzbwatch-sample.yml"    "${pkgdir}/etc/nzbwatch-sample.yml"
  install -Dm755 "${srcdir}/${_gitname}/nzbwatch.rb"            "${pkgdir}/usr/bin/nzbwatch.rb"
  install -Dm777 "${srcdir}/${_gitname}/nzbwatch.service"       "${pkgdir}/usr/lib/systemd/user/nzbwatch.service"
}

pkgver() {
  cd "${_gitname}"
  printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}
