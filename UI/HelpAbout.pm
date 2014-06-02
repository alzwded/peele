package UI::HelpAbout;

use Wx;
use Wx::Html;
use wxPerl::Constructors;

sub ShowAbout {
    my $info = Wx::AboutDialogInfo->new();
    $info->SetName("Peele");
    $info->SetVersion("0.9"); # bogus version; this probably won't be modified for a long time
    $info->SetDescription("Plugin-based Expression Engine within a Lite Environment");
    $info->SetCopyright("(C) 2014 Vlad Mesco");
    $info->SetWebSite("http://github.com/alzwded/peele");
    $info->SetLicence(
    <<EOT
Copyright (c) 2014, Vlad Mesco
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
EOT
    );
    Wx::AboutBox($info);
}

sub ShowHelp {
    -f "help.html" or return;
    my $f = wxPerl::Frame->new(undef, 'Peele Help', style => &Wx::wxDEFAULT_FRAME_STYLE | &Wx::wxRESIZE_BORDER);
    my $html = Wx::HtmlWindow->new($f);
    $html->LoadFile("help.html");
    $f->Show();
}

1;
