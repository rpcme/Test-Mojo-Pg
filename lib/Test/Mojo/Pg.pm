package Test::Mojo::Pg;
use Mojo::Base -base;
use File::Basename;
use Mojo::Pg;
use Mojo::Pg::Migrations;

has host     => undef;
has port     => undef;
has db       => 'testdb';
has username => undef;
has password => undef;
has migsql   => undef;
has verbose  => 0;

sub new {
  my ($class, %options) = @_;
  my $self = bless {}, $class;
  $self->host($options{host}) if defined $options{host};
  $self->port($options{port}) if defined $options{port};
  $self->db($options{db}) if defined $options{db};
  $self->username($options{username}) if defined $options{username};
  $self->password($options{password}) if defined $options{password};
  $self->migsql($options{migsql}) if defined $options{migsql};
  return $self;
}

sub construct {
  my ($self) = @_;
  $self->drop_database;
  $self->create_database;
}

sub deconstruct {
  my ($self) = @_;
  $self->drop_database;
}

sub get_version {
  my ($self, $p) = @_;
  my $q_v   = 'SELECT version()';
  my $q_sv  = 'SHOW server_version';
  my $q_svn = 'SHOW server_version_num';

  my $full_version       = $p->db->query($q_v)->array->[0];
  my $server_version     = $p->db->query($q_sv)->array->[0];
  my $server_version_num = $p->db->query($q_svn)->array->[0];
  say '-> Pg full version is ' . $full_version
    if $self->verbose;
  say '-> Pg server_version is ' . $server_version
    if $self->verbose;
  say '-> Pg server_version_num is ' . $server_version_num
    if $self->verbose;
  return $server_version_num;
}

sub connstring {
  my ($self, $dbms) = @_;
  my $prefix = 'postgresql://';
  my $result = $prefix
             . $self->_connstring_user
             . $self->_connstring_server;
  return $result if defined $dbms;

  $result .= '/' . $self->db if defined $self->db;

  return $result;
}

sub _connstring_server {
  my ($self) = @_;
  return $self->host . ':' . $self->port
    if defined $self->host and defined $self->port;
  return $self->host if defined $self->host;
  return '';
}

sub _connstring_user {
  my ($self) = @_;
  return $self->username . '@' if defined $self->username;
  return '';
}

sub drop_database {
  my ($self) = @_;
  # Connect to the DBMS
  my $c = $self->connstring(1);
  my $p = Mojo::Pg->new($c);
  $self->remove_connections($p);
  $p->db->query('drop database if exists ' . $self->db . ';');
  $p->db->disconnect;
}

sub create_database {
  my ($self) = @_;
  my $c = $self->connstring(1);
  my $p = Mojo::Pg->new($c);
  $p->db->query('create database '. $self->db .';');

  if (not defined $self->migsql) {
    warn 'No migration script - empty database created.';
    $p->db->disconnect;
    return 1;
  }

  my $migrations = Mojo::Pg::Migrations->new(pg => $p);
  $migrations->from_file($self->migsql);
  $migrations->migrate(0)->migrate;
  $p->db->disconnect;
  return 1;
}

sub remove_connections {
  my ($self, $p) = @_;
  my $pf = $self->get_version($p) < 90200 ? 'procpid' : 'pid';
  my $q = q|SELECT pg_terminate_backend(pg_stat_activity.| . $pf . q|) |
        . q|FROM   pg_stat_activity |
        . q|WHERE  pg_stat_activity.datname='| . $self->db . q|' |
        . q|AND    | . $pf . q| <> pg_backend_pid();|;
  $p->db->query($q);
}

1;

__END__
