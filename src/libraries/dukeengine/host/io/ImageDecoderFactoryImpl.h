#ifndef IMAGEDECODERFACTORYIMPL_H_
#define IMAGEDECODERFACTORYIMPL_H_

#include "IOPlugin.h"
#include "ImageDecoderFactory.h"

#include <dukehost/PluginManager.h>
#include <dukehost/HostImpl.h>

#include <boost/shared_ptr.hpp>
#include <boost/algorithm/string/predicate.hpp>
#include <boost/unordered_map.hpp>

#include <string>

class ImageDecoderFactoryImpl : public ::openfx::host::HostImpl, public ImageDecoderFactory {
    ::openfx::host::PluginManager m_PluginManager;

    struct iequal_to : std::binary_function<std::string, std::string, bool> {
        bool operator()(std::string const& x, std::string const& y) const {
            return boost::algorithm::iequals(x, y, std::locale());
        }
    };

    struct ihash : std::unary_function<std::string, std::size_t> {
        std::size_t operator()(std::string const& x) const {
            std::size_t seed = 0;
            std::locale locale;
            for (std::string::const_iterator it = x.begin(); it != x.end(); ++it)
                boost::hash_combine(seed, std::toupper(*it, locale));
            return seed;
        }
    };
    // hash map
    typedef boost::shared_ptr<IOPlugin> SharedIOPlugin;
    typedef boost::unordered_map<std::string, SharedIOPlugin, ihash, iequal_to> ExtensionToDecoderMap;
    ExtensionToDecoderMap m_Map;

public:
    ImageDecoderFactoryImpl();
    virtual ~ImageDecoderFactoryImpl();

    virtual FormatHandle getImageDecoder(const char* extension, bool &delegateRead, bool &isFormatUncompressed) const;
    virtual bool readImageHeader(FormatHandle decoder, const char* filename, ImageDescription& description) const;
    virtual bool decodeImage(FormatHandle decoder, const ImageDescription& description) const;
};

#endif /* IMAGEDECODERFACTORYIMPL_H_ */
