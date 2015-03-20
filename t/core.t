use Test::More;
use Test::Mojo::Pg;
isa_ok my $p = Test::Mojo::Pg->new, 'Test::Mojo::Pg';

# properties - host, port, db, username, password, sql
is $p->host('myhost'), $p;
is $p->host, 'myhost';
is $p->port('12345'), $p;
is $p->port, '12345';
is $p->db('mydb'), $p;
is $p->db, 'mydb';
is $p->username('riche'), $p;
is $p->username, 'riche';
is $p->password('r1cH3'), $p;
is $p->password, 'r1cH3';
is $p->migsql('sql1.sql'), $p;
is $p->migsql, 'sql1.sql';

# connection string testing
isa_ok my $c1 = Test::Mojo::Pg->new(db => 'db1'), 'Test::Mojo::Pg';
is $c1->connstring, 'postgresql:///db1';
is $c1->connstring(1), 'postgresql://';

isa_ok my $c2 = Test::Mojo::Pg->new(host=>'myhost', db => 'db1'), 'Test::Mojo::Pg';
is $c2->connstring, 'postgresql://myhost/db1';
is $c2->connstring(1), 'postgresql://myhost';

isa_ok my $c3 = Test::Mojo::Pg->new(host=>'myhost', port => 12345, db => 'db1'), 'Test::Mojo::Pg';
is $c3->connstring, 'postgresql://myhost:12345/db1';
is $c3->connstring(1), 'postgresql://myhost:12345';

done_testing();
