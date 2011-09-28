# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "floor_manager"
  s.version = "0.1.2"

  s.authors = ["Kaspar Schiess"]
  s.email = "kaspar.schiess@absurd.li"
  s.extra_rdoc_files = ["README"]
  s.files = %w(HISTORY.txt LICENSE README) + Dir.glob("{lib}/**/*")
  s.homepage = "http://github.com/kschiess/floor_manager"
  s.rdoc_options = ["--main", "README"]
  s.require_paths = ["lib"]
  s.summary = "Allows creation of a whole graph of objects on the fly during testing"
end
