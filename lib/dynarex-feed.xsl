body {background-color: #aa5}

#records {background-color: #888;}
/*#records>ul{list-style-type: none;}*/
#records>ul:first-child {
  background-color: #acc;
  -moz-column-count: 4; -moz-column-gap: 1em; -moz-column-rule: 1px solid black; -webkit-column-count: 4; -webkit-column-gap: 1em; -webkit-column-rule: 1px solid black;
  margin:0.7em 1.3em; padding: 0.8em;
}
#records>ul:first-child>li {margin: 0.2em; padding: 0.4em;}
#records>ul+ul {background-color: #ecf;list-style-type: none; margin: 0.2em; padding: 0.2em}
#records>ul+ul>li {   background-color: #956;}

#records>ul+ul>li:nth-child(even) { background:#4b3;  }
#records>ul+ul>li>div {
  background-color: #9ca;
  -moz-column-count: 3; -moz-column-gap: 1em; -moz-column-rule: 1px solid black; -webkit-column-count: 3; -webkit-column-gap: 1em; -webkit-column-rule: 1px solid black;
  margin:0.7em 0.3em; padding: 0.4em;

}
#records>ul>li:nth-child(even)>div { background-color: #ba8;  }
#records>ul>li>div>a>h1 {background-color: transparent; font-size: 1.0em;}


