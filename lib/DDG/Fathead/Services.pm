package DDG::Fathead::Services;

use DDG::Fathead;

primary_example_queries 'port 53 udp';

secondary_example_queries
    'port 3306',
    '1134 udp';

description '';

name 'Services';

icon_url '/i/iana.org.ico';

source 'IANA';

code_url 'https://github.com/duckduckgo/zeroclickinfo-fathead/tree/master/share/services';

topics 'geek', 'sysadmin', 'special_interest';

category 'reference';

attribution web => ['http://dylansserver.com','Dylan Lloyd'],
            email => ['dylan@dylansserver.com','Dylan Lloyd'],
            github => ['https://github.com/nospampleasemam', 'nospampleasemam'];

1;
