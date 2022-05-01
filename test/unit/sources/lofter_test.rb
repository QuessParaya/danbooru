require "test_helper"

module Sources
  class LofterTest < ActiveSupport::TestCase
    context "A lofter post" do
      setup do
        @img = "https://imglf4.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJUFczb2RKSVlpMHJkNy9kc3BSQVQvQm5DNzB4eVhxay9nPT0.png?imageView&thumbnail=1680x0&quality=96&stripmeta=0"
        @ref = "https://gengar563.lofter.com/post/1e82da8c_1c98dae1b"
        @source = Source::Extractor.find(@img, @ref)
        @source2 = Source::Extractor.find(@ref)
      end

      should "get the artist name" do
        assert_equal("gengar563", @source.artist_name)
      end

      should "get the commentary" do
        assert_match(/发了三次发不出有毒…… \n.*\n失去耐心.jpg/, @source.dtext_artist_commentary_desc)
      end
      should "get profile url" do
        assert_equal("https://gengar563.lofter.com", @source.profile_url)
      end

      should "get the image urls" do
        images = %w[
          https://imglf3.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJQ1RxY0lYaU1UUE9tQ0NvUE9rVXFpOFFEVzMwbnQ4aEFnPT0.jpg
          https://imglf3.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJRWlXYTRVOEpXTU9TSGt3TjBDQ0JFZVpZMEJtWjFneVNBPT0.png
          https://imglf6.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJR1d3Y2VvbTNTQlIvdFU1WWlqZHEzbjI4MFVNZVdoN3VBPT0.png
          https://imglf6.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJTi83NDRDUjNvd3hySGxEZFovd2hwbi9oaG9NQ1hOUkZ3PT0.png
          https://imglf4.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJUFczb2RKSVlpMHJkNy9kc3BSQVQvQm5DNzB4eVhxay9nPT0.png
          https://imglf4.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJSStJZE9RYnJURktHazdIVHNNMjQ5eFJldHVTQy9XbDB3PT0.png
          https://imglf3.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJSzFCWFlnUWgzb01DcUdpT1lreG5yQjJVMkhGS09HNGR3PT0.png
        ]

        assert_equal(images, @source2.image_urls)
      end

      should "download the full-size image" do
        assert_downloaded(2_739_443, @source.image_urls.sole)
      end

      should "find the correct artist" do
        @artist = FactoryBot.create(:artist, name: "gengar563", url_string: "https://gengar563.lofter.com")
        assert_equal([@artist], @source.artists)
      end
    end

    context "A different CSS schema" do
      should "still find all the data" do
        source1 = Source::Extractor.find("https://yuli031458.lofter.com/post/3163d871_1cbdc5f6d")

        assert_equal(["https://imglf5.lf127.net/img/Mm55d3lNK2tJUWpNTjVLN0MvaTRDc1UvQUFLMGszOHRvSjV6S3VSa1lwa3BDWUtVOWpBTHBnPT0.jpg"], source1.image_urls)
        assert_not_empty(source1.tags)
      end
    end

    context "A bad link" do
      should "correctly get the full size" do
        source = Source::Extractor.find("https://imglf4.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJUFczb2RKSVlpMHJkNy9kc3BSQVQvQm5DNzB4eVhxay9nPT0.png?imageView&thumbnail=1680x0&quality=96&stripmeta=0")
        assert_equal(["https://imglf4.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJUFczb2RKSVlpMHJkNy9kc3BSQVQvQm5DNzB4eVhxay9nPT0.png"], source.image_urls)
        assert_nothing_raised { source.to_h }
      end
    end

    context "A dead link" do
      should "not raise anything" do
        source = Source::Extractor.find("https://gxszdddd.lofter.com/post/322595b1_1ca5e6f66")
        assert_nothing_raised { source.to_h }
      end
    end

    should "Parse Lofter URLs correctly" do
      assert(Source::URL.image_url?("https://imglf3.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJSzFCWFlnUWgzb01DcUdpT1lreG5yQjJVMkhGS09HNGR3PT0.png?imageView&thumbnail=1680x0&quality=96&stripmeta=0"))
      assert(Source::URL.image_url?("http://imglf0.nosdn.127.net/img/cHl3bXNZdDRaaHBnNWJuN1Y4OXBqR01CeVBZSVNmU2FWZWtHc1h4ZTZiUGxlRzMwZnFDM1JnPT0.jpg "))

      assert(Source::URL.page_url?("https://gengar563.lofter.com/post/1e82da8c_1c98dae1b"))

      assert(Source::URL.profile_url?("https://www.lofter.com/front/blog/home-page/noshiqian"))
      assert(Source::URL.profile_url?("http://www.lofter.com/app/xiaokonggedmx"))
      assert(Source::URL.profile_url?("http://www.lofter.com/blog/semblance"))
      assert(Source::URL.profile_url?("http://gengar563.lofter.com"))
    end
  end
end
