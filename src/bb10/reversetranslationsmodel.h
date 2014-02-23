/*
 *  TAO Translator
 *  Copyright (C) 2013-2014  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
 *
 *  $Id: $Format:%h %ai %an$ $
 *
 *  This file is part of TAO Translator.
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef REVERSETRANSLATIONSMODEL_H
#define REVERSETRANSLATIONSMODEL_H

#include <bb/cascades/QListDataModel>

class ReverseTranslations: public QList<QVariantMap>
{
    Q_DECLARE_TR_FUNCTIONS(ReverseTranslationsModel)

public:
    void append(const QString &term, const QStringList &synonyms, const QStringList &translations);
};

class ReverseTranslationsModel: public bb::cascades::QMapListDataModel
{
    Q_OBJECT

public:
    ReverseTranslationsModel(QList<QVariantMap> *list, QObject *parent = NULL);
};
Q_DECLARE_METATYPE(ReverseTranslationsModel *)

#endif // REVERSETRANSLATIONSMODEL_H
